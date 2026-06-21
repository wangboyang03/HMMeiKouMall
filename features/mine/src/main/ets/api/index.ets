import { Constants, LoginResponseViewModel, NetworkRequestUtil } from "basic";
import { HuaweiLoginRequest, LoginFormViewModel } from "../models";

export const LoginRequestApi = (params: LoginFormViewModel) => NetworkRequestUtil.post<LoginResponseViewModel>(Constants.LOGIN_API, params)

// 华为一键登录
export const HuaweiLoginRequestApi = (params: HuaweiLoginRequest) => NetworkRequestUtil.post<LoginResponseViewModel>(Constants.HUAWEI_LOGIN_REQUEST_API, params)