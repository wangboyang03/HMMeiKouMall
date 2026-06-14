import { Log } from '@abner/log'

Log.init({
  tag: 'MK_Logger',
  domain: 0x0000,
  close: false,
  isHilog: true,
  showLogLocation: true,
  logSize: 700
})

export {Log as Logger}