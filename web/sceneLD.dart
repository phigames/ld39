part of ld39;

class SceneLD extends Scene {

  bool ejected;

  SceneLD() : super(0x222222, 'scene', 300) {
    ejected = false;
  }

  void preload() {
    super.preload();
    game.load.image('cover', 'res/cover.png');
    game.load.image('button', 'res/button.png');
    game.load.spritesheet('switch', 'res/switch.png', 10, 30);
    game.load.image('battery_3', 'res/battery_3.png');
    game.load.image('battery_9', 'res/battery_9.png');
    game.load.image('wire', 'res/wire.png');
    game.load.spritesheet('display_1', 'res/display_1.png', 70, 20);
  }

  void create() {
    super.create();
    devices.add(new Device('1a_E', '1b_E', Battery.NINE_V, game.add.sprite(70, 260, 'display_1')));
    //devices.add(new Device('2a_A', '2b_A', Battery.THREE_V));
    //devices.add(new Device('3a_A', '4a_B', Battery.THREE_V));
    //devices.add(new Device('4a_A', '4b_A', Battery.NINE_V, null));
    devices.add(new Device('5a_E', '5b_E', Battery.NINE_V, null, switchLightsOn, switchLightsOff));
    removables.add(new Removable(this, 'cover', 695, 200, false, -50, 25)
      ..onRemoved = ejectFromCover);
    Removable button1 = new Removable(this, 'button', 210, 110, true, null, null);
    button1.onRemoved = () => ejectFromButton(button1.sprite, '2a');
    Removable button2 = new Removable(this, 'button', 240, 110, true, null, null);
    button2.onRemoved = () => ejectFromButton(button2.sprite, '2b');
    Removable button3 = new Removable(this, 'button', 425, 305, true, null, null);
    button3.onRemoved = () => ejectFromButton(button3.sprite, '3a');
    removables.add(button1);
    removables.add(button2);
    removables.add(button3);
    switches.add(new Switch(this, 'switch', 75, 235, false));
    switches.add(new Switch(this, 'switch', 95, 235, true));
    switches.add(new Switch(this, 'switch', 135, 325, false));
    wires.add(new Wire(this, '4a', 545, 115, true, 18, 445, 215, true, null, 1));
    wires.add(new Wire(this, '4b', 565, 115, true, 15, 645, 225, true, null, 1));
    batteries.add(new Battery(this, Battery.THREE_V, 500, 400));
    batteries.add(new Battery(this, Battery.THREE_V, 550, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 630, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 690, 400));
    batteries.add(new Battery(this, Battery.NINE_V, 750, 400));
    arm.bringToTop();
    game.world.bringToTop(flashlight);
    game.world.bringToTop(light);
    phaser.Graphics black = game.add.graphics();
    black.beginFill(0x222222);
    black.drawRect(0, 0, game.width, game.height);
    game.add.tween(black).to({ 'alpha': 0 }, 2000, null, true).onComplete.add((_) => black.destroy());
  }

  void switchLightsOn() {
      light.visible = false;
      game.stage.mask = null;
  }

  void switchLightsOff() {
    light.visible = true;
    game.stage.mask = lightMask;
  }

  void render() {
    super.render();
  }

  void update() {
    super.update();
    for (Removable removable in removables) {
      removable.update();
      if (removable.small) {
        if (mouseClicked && distance(removable.sprite.body.x, removable.sprite.body.y, flashlight.body.x, flashlight.body.y) <= 25) {
          removable.hit();
          flashlight.animations.play('hit', 15, false);
          mouseClicked = false;
        }
      } else if (mouseClicked && game.physics.p2.hitTest(new phaser.Point(mouseX, mouseY), [ removable.sprite.body ]).length > 0) {
        removable.hit();
        flashlight.animations.play('hit', 15, false);
        mouseClicked = false;
      }
    }
    bool switchesOn = true;
    for (Switch button in switches) {
      if (distance(button.spriteOff.body.x, button.spriteOff.body.y, flashlight.body.x, flashlight.body.y) <= 25) {
        if (button.switched == false) {
          button.hit();
          //flashlight.animations.play('hit', 15, false);
        }
      } else {
        button.switched = false;
      }
      if (!button.spriteOn.visible) {
        switchesOn = false;
      }
    }
    if (switchesOn && !ejected) {
      ejectFromSwitches();
      ejected = true;
    }
    for (Wire wire in wires) {
      wire.update();
    }
    for (Battery battery in batteries) {
      battery.update();
      if (mouseClicked && distance(mouseX, mouseY, battery.sprite.body.x, battery.sprite.body.y) < 60) {
        battery.hit(angle(mouseX, mouseY, battery.sprite.body.x, battery.sprite.body.y));
        mouseClicked = false;
        flashlight.animations.play('hit', 15, false);
      }
    }
    lightRadius -= game.time.elapsed / 1000;
    if (lightRadius < 0) {
      lightRadius = 0;
      // electrocute?
    }
  }

  void ejectFromSwitches() {
    wires.add(new Wire(this, '1a', 130, 230, true, 13, 130, 231));
    wires.add(new Wire(this, '1b', 130, 230, true, 13, 131, 230));
    arm.bringToTop();
    flashlight.bringToTop();
    light.bringToTop();
  }

  void ejectFromButton(phaser.Sprite<p2.Body> button, String id) {
    wires.add(new Wire(this, id, button.x, button.y, true, 10, button.x, button.y, true, button, 8));
    button.bringToTop();
    arm.bringToTop();
    flashlight.bringToTop();
    light.bringToTop();
  }

  void ejectFromCover() {
    wires.add(new Wire(this, '5a', 675, 205, true, 2, 695, 195, false));
    wires.add(new Wire(this, '5b', 695, 205, true, 3, 715, 195, false));
    flashlight.bringToTop();
    light.bringToTop();
  }

}