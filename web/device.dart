part of ld39;

class Device {

  String endIDPlus, endIDMinus;
  int targetVoltage;
  bool working;
  Function() onRepaired, onBroken;
  phaser.Sprite sprite;

  Device(this.endIDPlus, this.endIDMinus, this.targetVoltage, this.sprite, [this.onRepaired, this.onBroken]) {
    working = false;
    if (sprite != null) {
      sprite.animations.add('test');
      sprite.visible = false;
    }
  }

  bool check(Map<String, AttachableEnd> ends) {
    if (ends[endIDPlus] != null && ends[endIDMinus] != null &&
        ends[endIDPlus].battery != null && ends[endIDMinus].battery != null &&
        ends[endIDPlus].battery == ends[endIDMinus].battery &&
        ends[endIDPlus].battery.voltage == targetVoltage) {
      if (!working) {
        working = true;
        if (sprite != null) {
          sprite.animations.play('test', 2, true);
          sprite.visible = true;
        }
        if (onRepaired != null) {
          onRepaired();
        }
      }
      return true;
    }
    if (working) {
      if (sprite != null) {
        sprite.animations.stop('test');
        sprite.visible = false;
      }
      working = false;
      if (onBroken != null) {
        onBroken();
      }
    }
    return false;
  }

}