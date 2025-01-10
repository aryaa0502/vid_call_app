// ignore_for_file: public_member_api_docs, sort_constructors_first
class MeetingDetail {
  String? id;
  String? hostId;
  String? hostName;

  MeetingDetail({
    this.id,
    this.hostId,
    this.hostName,
  });
  
  factory MeetingDetail.fromJson(dynamic json) {
    return MeetingDetail(
      id: json["_id"],
      hostId: json["hostId"],
      hostName: json["hostName"]
    );
  }
}
