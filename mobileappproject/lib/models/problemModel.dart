import 'package:cloud_firestore/cloud_firestore.dart';

class Problem {
  final String problemID;
  final String answer;
  final String creator;
  final bool isShared;
  final String picture;
  final String problemtext;
  final List<dynamic> multipleWrongAnswers;
  final DocumentReference reference;

  Problem.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map != null),
        assert(map['answer'] != null),
        assert(map['creator'] != null),
        assert(map['isShared'] != null),
        assert(map['problemtext'] != null),
        answer = map['answer'],
        creator = map['creator'],
        isShared = map['isShared'],
        picture = map['picture'],
        problemtext = map['problemtext'],
        multipleWrongAnswers = map['multipleWrongAnswers'],
        problemID = reference.id;

  Problem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "$problemtext:$answer>";
}