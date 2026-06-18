export interface LoginForm {
  account: string
  password: string
}

@ObservedV2
export class LoginFormViewModel implements LoginForm {
  @Trace account: string = ""
  @Trace password: string = ""

  constructor(models: LoginForm) {
    this.account = models.account
    this.password = models.password
  }
}