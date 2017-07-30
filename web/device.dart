part of ld39;

class Device {

  String endIDPlus, endIDMinus;
  int targetVoltage;
  bool working;
  Function onRepaired, onBroken;

  Device(this.endIDPlus, this.endIDMinus, this.targetVoltage, [this.onRepaired, this.onBroken]) {
    working = false;
  }

  bool check(Map<String, AttachableEnd> ends) {
    if (ends[endIDPlus] != null && ends[endIDPlus].battery != null &&
        ends[endIDPlus].battery == ends[endIDMinus].battery &&
        ends[endIDPlus].battery.voltage == targetVoltage) {
      print('working');
      if (!working) {
        working = true;
        onRepaired();
      }
      return true;
    }
    if (working) {
      working = false;
      onBroken();
    }
    return false;
  }

}