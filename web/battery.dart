part of ld39;

class Battery {

  phaser.Sprite<p2.Body> sprite;
  int voltage;
  bool plusAttached, minusAttached;

  Battery(Scene scene, this.voltage, num x, num y) {
    sprite = game.add.sprite(x, y, 'battery_$voltage');
    game.physics.p2.enable(sprite);
    sprite.body.setCollisionGroup(scene.mouseCollisionGroup);
    sprite.body.collides(scene.mouseCollisionGroup);
    sprite.body.collides(scene.wireCollisionGroup);
    plusAttached = minusAttached = false;
  }

  void hit() {
    sprite.body.velocity.x = random.nextDouble() * 2000 - 1000;
    sprite.body.velocity.y = random.nextDouble() * 2000 - 1000;
  }

}