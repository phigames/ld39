part of ld39;

class Wire {

  p2.RevoluteConstraint constraintStart, constraintEnd, tearConstraint;

  Wire(Scene scene, String key, num startX, num startY, bool constrainedStart, int length, [int tearPoint, num endX, num endY]) {
    phaser.Sprite<p2.Body> lastRect;
    phaser.Sprite<p2.Body> newRect;
    num width = 5;
    num height = 20;
    num maxForce = 20000;
    p2.CollisionGroup collisionGroup = game.physics.p2.createCollisionGroup();
    for (int i = 0; i < length; i++) {
      newRect = game.add.sprite(startX, startY + i * height, key);
      game.physics.p2.enable(newRect);
      scene.flashlight.body.collides(collisionGroup);
      newRect.body.setCollisionGroup(collisionGroup);
      if (lastRect == null) {
        if (constrainedStart) {
          p2.Body fixBody = new p2.Body(game);
          game.physics.p2.addBody(fixBody);
          p2.RevoluteConstraint constraint = constraintStart = game.physics.p2.createRevoluteConstraint(newRect, [ 0, -height / 2 + width / 2 ], fixBody, [ startX, startY ]);
          if (i == tearPoint) {
            tearConstraint = constraint;
          }
        }
      } else {
        p2.RevoluteConstraint constraint = game.physics.p2.createRevoluteConstraint(newRect, [ 0, -height / 2 + width / 2 ], lastRect, [ 0, height / 2 - width / 2 ]);
        if (i == tearPoint) {
          tearConstraint = constraint;
        }
        newRect.body.collides(scene.mouseCollisionGroup);
      }
      lastRect = newRect;
    }
    if (endX != null && endY != null) {
      p2.Body fixBody = new p2.Body(game);
      game.physics.p2.addBody(fixBody);
      constraintEnd = game.physics.p2.createRevoluteConstraint(lastRect, [ 0, height / 2 - width / 2 ], fixBody, [ endX, endY ]);
    }
  }

  void update() {
    if (tearConstraint != null && tearConstraint.equations[0].multiplier.abs() > 500) {
      game.physics.p2.removeConstraint(tearConstraint);
    }
  }

}