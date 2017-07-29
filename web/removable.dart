part of ld39;

class Removable {

  Scene scene;
  phaser.Sprite<p2.Body> sprite; // store body?
  num originX, originY;
  num pivotX, pivotY;
  num damage;
  num shakeTime;

  Removable(this.scene, String key, num x, num y, [this.pivotX, this.pivotY]) {
    sprite = game.add.sprite(x, y, key);
    game.physics.p2.enable(sprite);
    originX = x;
    originY = y;
    damage = 0;
    shakeTime = 0;
  }

  void remove() {
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    sprite.body.collides(scene.wireCollisionGroup);
    if (pivotX != null && pivotY != null) {
      p2.Body fixedBody = new p2.Body(game);
      game.physics.p2.addBody(fixedBody);
      game.physics.p2.createRevoluteConstraint(sprite, [ pivotX, pivotY ], fixedBody, [ sprite.x + pivotX, sprite.y + pivotY ]);
    }
    //sprite.body.velocity.y = 50;
  }

  void hit() {
    damage += 0.5;
    if (damage > 2) {
      remove();
    }
    shakeTime = 0.2;
  }

  void update() {
    damage -= game.time.elapsed / 1000;
    if (damage < 0) {
      damage = 0;
    }
    if (shakeTime > 0) {
      shakeTime -= game.time.elapsed / 1000;
      if (shakeTime < 0) {
        shakeTime = 0;
        sprite.body.x = originX;
        sprite.body.y = originY;
      } else {
        sprite.body.x = originX + random.nextDouble() * 10 - 5;
        sprite.body.y = originY + random.nextDouble() * 10 - 5;
      }
    }
  }

}