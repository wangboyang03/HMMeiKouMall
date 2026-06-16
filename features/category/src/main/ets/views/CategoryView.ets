import { TextToSpeechEngine } from "basic";

@Component
export struct CategoryView {
  @State message: string = 'Hello World';
  build() {
    Row() {
      TextInput({
        text: $$this.message
      }).onSubmit((value) => {
        this.message = value.toString();
      }).width('50%')
      Button('开始播放').onClick((_: ClickEvent) => TextToSpeechEngine.getInstance().speakFromText(this.message))
    }
  }
}