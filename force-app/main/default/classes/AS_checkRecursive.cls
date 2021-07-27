public class AS_checkRecursive {

  public static boolean run_copyOrderproductstoOrderLineItem = true;
  public static boolean run_ppaymentRoll = true;
  public static boolean run_calculateGST = true;

  public static boolean runOnce_AS_copyOrderproductstoOrderLineItem() {
    if (run_copyOrderproductstoOrderLineItem) {
      run_copyOrderproductstoOrderLineItem = false;
      return true;
    } else {
      return run_copyOrderproductstoOrderLineItem;
    }
  }

  public static boolean runOnce_AS_ppaymentRoll() {
    if (run_ppaymentRoll) {
      run_ppaymentRoll = false;
      return true;
    } else {
      return run_ppaymentRoll;
    }
  }

  public static boolean runOnce_AS_calculateGST() {
    if (run_ppaymentRoll) {
      run_calculateGST = false;
      return true;
    } else {
      return run_calculateGST;
    }
  }
  


}