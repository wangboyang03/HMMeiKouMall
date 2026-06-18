import { Constants, LoginResponseViewModel, NetworkRequestUtil } from "basic";
import { LoginFormViewModel } from "../models";

export const LoginRequestApi = (params: LoginFormViewModel) => NetworkRequestUtil.post<LoginResponseViewModel>(Constants.LOGIN_API, params)