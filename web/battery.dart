part of ld39;

class Battery {

  static const num TEAR_THRESHOLD = 200;

  Scene scene;
  phaser.Sprite<p2.Body> sprite; // store body?
  int voltage;
  p2.RevoluteConstraint tearConstraintPlus, tearConstraintMinus;
  Wire tearWirePlus, tearWireMinus;
  p2.Body tearBodyPlus, tearBodyMinus;
  bool equilibriumPlus, equilibriumMinus;

  Battery(this.scene, this.voltage, num x, num y) {
    sprite = game.add.sprite(x, y, 'battery_$voltage');
    game.physics.p2.enable(sprite);
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    sprite.body.collides(scene.wireCollisionGroup);
    equilibriumPlus = equilibriumMinus = false;
  }

  void hit(num angle) {
    sprite.body.velocity.x = cos(angle) * 1000;
    sprite.body.velocity.y = sin(angle) * 1000;
  }

  void update() {
    if (tearConstraintPlus == null || tearConstraintMinus == null) {
      for (Wire wire in scene.wires) {
        for (p2.Body body in wire.attachableEnds) {
          if (distance(sprite.x, sprite.y, body.x, body.y) < 50) {
            if (tearConstraintPlus == null) {
              tearConstraintPlus = game.physics.p2.createRevoluteConstraint(sprite.body, [ -sprite.width / 2, 0], body, [ 0, 0]);
              tearWirePlus = wire;
              tearBodyPlus = body;
            } else if (tearConstraintMinus == null) {
              tearConstraintMinus = game.physics.p2.createRevoluteConstraint(sprite.body, [ sprite.width / 2, 0], body, [ 0, 0]);
              tearWireMinus = wire;
              tearBodyMinus = body;
            } else {
              break;
            }
            wire.attachableEnds.remove(body);
            sprite.body.setCollisionGroup(scene.wireCollisionGroup);
            break;
          }
        }
      }
    }
    if (tearConstraintPlus != null) {
      if (tearConstraintPlus.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibriumPlus) {
          game.physics.p2.removeConstraint(tearConstraintPlus);
          tearConstraintPlus = null;
          tearWirePlus.attachableEnds.add(tearBodyPlus);
        }
      } else if (!equilibriumPlus && tearConstraintPlus.equations[0].multiplier != 0) {
        equilibriumPlus = true;
      }
    }
    if (tearConstraintMinus != null) {
      if (tearConstraintMinus.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibriumMinus) {
          game.physics.p2.removeConstraint(tearConstraintMinus);
          tearConstraintMinus = null;
          tearWireMinus.attachableEnds.add(tearBodyMinus);
        }
      } else if (!equilibriumMinus && tearConstraintMinus.equations[0].multiplier != 0) {
        equilibriumMinus = true;
      }
    }
  }

}