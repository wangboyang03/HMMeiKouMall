import { AppSafeArea, Constants, Logger, NavigationBar } from "basic";
import { AppStorageV2 } from "@kit.ArkUI";
import { KeyboardAvoidMode } from '@kit.ArkUI';
import rcp from "@hms.collaboration.rcp";
import { util } from "@kit.ArkTS";
import { Message, Response, _RequestParams } from "../models";
import { application } from "@kit.AbilityKit";

const api_url: string = "https://api.modelarts-maas.com/v2/chat/completions"
const api_key: string = "vUaqycpKAzIAN5NtZmv7KxEfdkIVS6kY4fPw6VXpKj1GpnJtviw30YGV2LQ-RaAGbfOYO5nNpv1ZumYailJOzw"

@Component
export struct IntelligentAgentView {
  safeAreaValue?: AppSafeArea = AppStorageV2.connect(AppSafeArea, () => new AppSafeArea())
  session?: rcp.Session
  @State buffer: string = "" // 用于存储未处理完的数据
  @State chatHistory: Message[] = []
  @State responseData: string = ""
  @State textInput: string = ""
  Scroller?: Scroller = new Scroller()
  @State words: string = ""

  async fetchSSEStreamAndParse() {
    // 1.在请求拦截器里夹带私货 注入token
    class RequestInterceptor implements rcp.Interceptor {
      intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
        if (context.request.headers) {
          context.request.headers.authorization = `Bearer ${api_key}` // 携带token
        }
        return next.handle(context);
      }
    }

    // 2.创建会话对象并配置参数
    try {
      this.session = rcp.createSession({
        interceptors: [new RequestInterceptor()],
        requestConfiguration: {
          tracing: {
            httpEventsHandler: {
              onDataReceive: (arrayBuffer) => {
                // Logger.info(buffer)
                const uint8Array = new Uint8Array(arrayBuffer)
                const textDecoder = util.TextDecoder.create('utf-8') // 创建TextDecoder对象
                const chunk = textDecoder.decodeToString(uint8Array)
                this.buffer += chunk
                // Logger.info(this.buffer)
                const lines = this.buffer.split('\n') // 按行处理数据
                this.buffer = lines[lines.length - 1] // 保留最后一行数据

                // 循环拉取流式数据
                for (let i = 0; i < lines.length - 1; i++) {
                  const line = lines[i].trim()
                  if (!line) {
                    continue;
                  }
                  // Logger.info(line)
                  if (line.startsWith('data:')) {
                    try {
                      const jsonString = line.slice(5) // 删除"data:"前缀
                      if (jsonString == '[DONE]') {
                        // Logger.info(jsonString)
                        continue;
                      }
                      const data = JSON.parse(jsonString) as Response
                      const content = data.choices?.[0]?.delta?.content ?? "" // 本次返回的内容
                      if (content) {
                        this.responseData += content // 追加本次返回的内容
                        // Logger.info(this.responseData)
                        if (this.chatHistory.length > 0) {
                          this.chatHistory[this.chatHistory.length - 1] = {
                            role: 'assistant',
                            content: this.responseData
                          } as Message
                          this.chatHistory = [...this.chatHistory]
                          this.Scroller?.scrollEdge(Edge.Bottom) // 接收到数据了 页面开始自动滚动 到底部
                        }

                        // const finishReason = data.choices?.[0]?.finish_reason // 判断是否结束
                        // if (finishReason == 'stop') {
                        //   Logger.info("finished") // 结束
                        // }
                      }
                    } catch (error) {
                      Logger.error(error)
                    }
                  }
                }
                return arrayBuffer.byteLength
              },
              onDataEnd: () => {
                this.responseData = "" // 开启新的回复
              }
            }
          }
        }
      })
    } catch (error) {
      Logger.error(error)
    }

    // 3. 创建角色并发送请求
    const params: _RequestParams = {
      "model": "DeepSeek-V3",
      "max_tokens": 1024,
      "messages": [{
        role: "system",
        content: this.words
      }, {
        role: "user",
        content: this.textInput
      }],
      "stream": true, // 开启流式返回
      "stream_options": { "include_usage": true }, // 在流式输出时是否展示使用的token数目。只有当stream为True时改参数才会生效。
      "temperature": 1.0 // 控制采样随机性的浮点数，值较低时模型更具确定性，值较高时模型更具创造性。"0"表示贪婪取样。默认为1.0。
    }
    // const request = new rcp.Request(api_url, "POST", {}, params)
    const res = await this.session?.post(api_url, params)
    return res
  }

  async sendMessage() {
    if (!this.textInput.trim()) {
      return
    }
    this.chatHistory.push({ content: this.textInput, role: 'user' })
    this.textInput = ""
    this.chatHistory.push({ content: '正在思考中，客官请稍后。', role: 'assistant' })
    await this.fetchSSEStreamAndParse()
  }

  async rawfileToJsonString() {
    const moduleContext = await application.createModuleContext(this.getUIContext().getHostContext(), Constants.INTELLIGENT_MODULE_NAME)
    const uni8Array = await moduleContext.resourceManager.getRawFileContent("rules.json")
    const decoder = new util.TextDecoder()
    const res = decoder.decodeToString(uni8Array)
    this.words = JSON.stringify(JSON.parse(res))
  }

  async aboutToAppear(): Promise<void> {
    // this.api_url = "https://api.modelarts-maas.com/v2/chat/completions"
    // this.api_key = "vUaqycpKAzIAN5NtZmv7KxEfdkIVS6kY4fPw6VXpKj1GpnJtviw30YGV2LQ-RaAGbfOYO5nNpv1ZumYailJOzw"
    // this.fetchSSEStreamAndParse()
    this.rawfileToJsonString()
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET) // 键盘避让 禁止TabBar遮挡输入框
  }

  build() {
    Column() {
      NavigationBar({
        title: '虚拟购物助手',
        showLeftIcon: false,
        showRightIcon: false
      })

      Scroll(this.Scroller) {
        Column() {
          ForEach(this.chatHistory, (item: Message, _) => {
            if (item.role == "assistant" || item.role == "system") {
              this.robotMessage(item)
            }
            if (item.role == "user") {
              this.userMessage(item)
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('80%')

      Row() {
        TextInput({ text: $$this.textInput, placeholder: '开始对话吧' })
          .width('80%')
          .fontSize(16)
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .height(40)
          .enterKeyType(EnterKeyType.Done)
          .onSubmit(() => this.sendMessage())

        Button('发送', { type: ButtonType.Normal })
          .enabled(this.textInput.trim() ? true : false)
          .margin({ left: 6 })
          .borderRadius(20)
          .onClick(() => this.sendMessage())
      }
      .width('100%')
      .padding(16)

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.under'))
  }

  @Builder robotMessage(item: Message) {
    Row() {
      Image($r('sys.media.AI_pause'))
        .width(26)
        .aspectRatio(1)
        .borderRadius(20)
        .margin({ right: 10 })
        .syncLoad(true)

      Text(item.content)
        .fontSize(16)
        .backgroundColor('#FFFFFF')
        .padding(12)
        .borderRadius(12)
        .margin({ right: 50 })
    }
    .width('100%')
    .margin({ top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder userMessage(item: Message) {
    Row() {
      Text(item.content)
        .fontSize(16)
        .backgroundColor('#ffc2ffb4')
        .padding(12)
        .borderRadius(12)
        .margin({ right: 12 })

      Image($r('sys.media.ohos_user_auth_icon_face'))
        .width(26)
        .aspectRatio(1)
        .borderRadius(20)
        .margin({ right: 10 })
        .syncLoad(true)
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .margin({ top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Top)
  }
}