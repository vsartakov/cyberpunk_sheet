enum StatId { int_, ref, tech, cool, attr, luck, ma, body, emp }

enum BodyPart { head, torso, rightArm, leftArm, rightLeg, leftLeg }

String statLabel(StatId id) => switch (id) {
      StatId.int_ => 'INT',
      StatId.ref => 'REF',
      StatId.tech => 'TECH',
      StatId.cool => 'COOL',
      StatId.attr => 'ATTR',
      StatId.luck => 'LUCK',
      StatId.ma => 'MA',
      StatId.body => 'BODY',
      StatId.emp => 'EMP',
    };

String bodyPartLabel(BodyPart p) => switch (p) {
      BodyPart.head => 'Голова',
      BodyPart.torso => 'Торс',
      BodyPart.rightArm => 'П. рука',
      BodyPart.leftArm => 'Л. рука',
      BodyPart.rightLeg => 'П. нога',
      BodyPart.leftLeg => 'Л. нога',
    };
