export interface ResponseData<T> {
  code: number;
  message: string;
  result: T;
}

export interface LoginResponse {
  account: string;
  avatar: string;
  birthday: string;
  cityCode: string;
  gender: string;
  id: string;
  mobile: string;
  nickname: string;
  profession: string;
  provinceCode: string;
  token: string;
}

@ObservedV2 export class LoginResponseViewModel implements LoginResponse{
  @Trace account: string = ""
  @Trace avatar: string = ""
  @Trace birthday: string = ""
  @Trace cityCode: string = ""
  @Trace gender: string = ""
  @Trace id: string = ""
  @Trace mobile: string = ""
  @Trace nickname: string = ""
  @Trace profession: string = ""
  @Trace provinceCode: string = ""
  @Trace token: string = ""

  constructor(models: LoginResponse) {
    this.account = models.account
    this.avatar = models.avatar
    this.birthday = models.birthday
    this.cityCode = models.cityCode
    this.gender = models.gender
    this.id = models.id
    this.mobile = models.mobile
    this.nickname = models.nickname
    this.profession = models.profession
    this.provinceCode = models.provinceCode
    this.token = models.token
  }
}

@ObservedV2 export class AppUserObject {
  @Trace User: LoginResponseViewModel = new LoginResponseViewModel({} as LoginResponse)
}