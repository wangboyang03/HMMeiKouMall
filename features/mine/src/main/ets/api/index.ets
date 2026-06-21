import { Constants, LoginResponseViewModel, NetworkRequestUtil } from "basic";
import { AddAddressRequest, AddressResponse, HuaweiLoginRequest, LoginFormViewModel } from "../models";

export const LoginRequestApi = (params: LoginFormViewModel) => NetworkRequestUtil.post<LoginResponseViewModel>(Constants.LOGIN_API, params)

// 华为一键登录
export const HuaweiLoginRequestApi = (params: HuaweiLoginRequest) => NetworkRequestUtil.post<LoginResponseViewModel>(Constants.HUAWEI_LOGIN_REQUEST_API, params)

export const getAddressListApi = () => NetworkRequestUtil.get<AddressResponse[]>(Constants.GET_ADDRESS_API)

export const addAddressApi = (data: AddAddressRequest) => NetworkRequestUtil.post<null>(Constants.ADD_ADDRESS_API, data)

export const updateAddressApi = (data: AddAddressRequest) => NetworkRequestUtil.put<null>(`${Constants.ADD_ADDRESS_API}/{${data.id}}`, data)