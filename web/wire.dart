part of ld39;

class Wire {

  static const num TEAR_THRESHOLD = 700;

  Scene scene;
  String id;
  p2.RevoluteConstraint constraintStart, constraintEnd, tearConstraint;
  p2.Body tearBodyA, tearBodyB;
  phaser.Sprite<p2.Body> endSprite;
  List<AttachableEnd> attachableEnds;
  bool equilibrium;

  Wire(this.scene, this.id, num startX, num startY, bool constrainedStart, int length, num endX, num endY, [bool constrainedEnd = false, this.endSprite, int tearPoint]) {
    attachableEnds = new List<AttachableEnd>();
    phaser.Sprite<p2.Body> lastRect;
    phaser.Sprite<p2.Body> newRect;
    num width = 20;
    num height = 10;
    num a = angle(startX, startY, endX, endY);
    num d = distance(startX, startY, endX, endY) / length;
    num dX = cos(a) * d;
    num dY = sin(a) * d;
    print('$dX, $dY');
    for (int i = 0; i < length; i++) {
      newRect = game.add.sprite(startX + i * dX, startY + i * dY, 'wire');
      game.physics.p2.enable(newRect);
      newRect.body.angle = a / PI * 180;
      newRect.body.setCollisionGroup(scene.wireCollisionGroup);
      if (lastRect == null) {
        if (constrainedStart) {
          p2.Body fixedBody = new p2.Body(game);
          game.physics.p2.addBody(fixedBody);
          constraintStart = game.physics.p2.createRevoluteConstraint(newRect, [ -width / 2 + height / 2, 0 ], fixedBody, [ startX, startY ]);
          if (i == tearPoint) {
            tearConstraint = constraintStart;
            tearBodyA = null;
            tearBodyB = newRect.body;
          }
        } else {
          AttachableEnd newEnd = new AttachableEnd(scene, id + '_S', newRect.body);
          attachableEnds.add(newEnd);
          scene.attachableEnds.add(newEnd);
        }
      } else {
        p2.RevoluteConstraint constraint = game.physics.p2.createRevoluteConstraint(newRect, [ -width / 2 + height / 2, 0 ], lastRect, [ width / 2 - height / 2, 0 ]);
        if (i == tearPoint) {
          tearConstraint = constraint;
          tearBodyA = lastRect.body;
          tearBodyB = newRect.body;
        }
        newRect.body.collides(scene.mouseCollisionGroup);
      }
      lastRect = newRect;
    }
    if (constrainedEnd) {
      if (endSprite == null) {
        p2.Body fixedBody = new p2.Body(game);
        game.physics.p2.addBody(fixedBody);
        constraintEnd = game.physics.p2.createRevoluteConstraint(lastRect, [ width / 2 - height / 2, 0], fixedBody, [ endX, endY]);
      } else {
        constraintEnd = game.physics.p2.createRevoluteConstraint(lastRect, [ width / 2 - height / 2, 0], endSprite.body, [ endSprite.width / 2, endSprite.height / 2]);
      }
    } else {
      AttachableEnd newEnd = new AttachableEnd(scene, id + '_E', newRect.body);
      attachableEnds.add(newEnd);
      scene.attachableEnds.add(newEnd);
      newRect.body.velocity.y = 100;
      newRect.body.velocity.x = 100;
    }
    equilibrium = false;
  }

  void update() {
    if (tearConstraint != null) {
      if (tearConstraint.equations[0].multiplier.abs() > TEAR_THRESHOLD) {
        if (equilibrium) {
          game.physics.p2.removeConstraint(tearConstraint);
          tearConstraint = null;
          if (tearBodyA != null) {
            AttachableEnd newEnd = new AttachableEnd(scene, id + '_A', tearBodyA);
            attachableEnds.add(newEnd);
            scene.attachableEnds.add(newEnd);
          }
          if (tearBodyB != null) {
            AttachableEnd newEnd = new AttachableEnd(scene, id + '_B', tearBodyB);
            attachableEnds.add(newEnd);
            scene.attachableEnds.add(newEnd);
          }
        }
      } else if (!equilibrium && tearConstraint.equations[0].multiplier != 0) {
        equilibrium = true;
      }
    }
  }

}

class AttachableEnd {

  Scene scene;
  String id;
  p2.Body body;
  Battery battery;

  AttachableEnd(this.scene, this.id, this.body) {
    print(id);
  }

  void attachBattery(Battery battery) {
    this.battery = battery;
    scene.checkVoltages();
  }

  void detachBattery() {
    this.battery = null;
  }

}