import { rcp } from "@kit.RemoteCommunicationKit";

@Component
export struct CategoryView {

  session = rcp.createSession({
    baseAddress: "https://meikou-api.itheima.net/"
  })
  build() {
    Button('rcp发请求').onClick(async (event: ClickEvent) => {
      const res = await this.session.get('home/banner')
      interface ApifoxModel {
        code: string;
        msg: string;
        result: Result[];
      }

      interface Result {
        hrefUrl: string;
        id: string;

        /**
         * 图片地址
         */
        imgUrl: string;
        type: string;
      }
      const data = res.toJSON() as ApifoxModel
      this.getUIContext().getPromptAction().showDialog({message: JSON.stringify(data)})

    })
  }
}