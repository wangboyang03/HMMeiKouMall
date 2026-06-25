import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { DownloadManager } from 'basic';

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    const formId = want.parameters && String(want.parameters["ohos.extra.param.key.form_identity"])

    DownloadManager.getInstance().downloadImageList(this.context, [
      'http://yjy-xiaotuxian-dev.oss-cn-beijing.aliyuncs.com/picture/2021-04-05/6fdcac19-dd44-442c-9212-f7ec3cf3ed18.jpg',
      'https://yanxuan-item.nosdn.127.net/31a81e6c7e4c173d1cf19d5abeb97550.png'
    ]).then((res) => {
      const formImages: Record<string, number> = DownloadManager.getInstance().createFormImages(res)
      formProvider.updateForm(formId, formBindingData.createFormBindingData({
        formImages,
        imageList: res
      }))
    })


    return formBindingData.createFormBindingData({
      message: "猜你喜欢"
    });
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}