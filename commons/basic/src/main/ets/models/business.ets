export interface ResponseData<T> {
  code: number;
  message: string;
  result: T;
}