import { hapPlugin } from '@hadss/hmrouter-plugin';
import { hapTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [hapPlugin()] /* HM Custom plugin to extend the functionality of Hvigor. */
}