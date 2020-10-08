class LogModel {
  int logId;
  String callerName;
  String callerPic;
  String receiverName;
  String receiverPic;
  String callStatus;
  String timestamp;

  LogModel({
    this.logId,
    this.callerName,
    this.callerPic,
    this.receiverName,
    this.receiverPic,
    this.callStatus,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map['log_id'] = this.logId;
    map['caller_name'] = this.callerName;
    map['caller_pic'] = this.callerPic;
    map['rec_name'] = this.receiverName;
    map['rec_pic'] = this.receiverPic;
    map['call_status'] = this.callStatus;
    map['timestamp'] = this.timestamp;
    return map;
  }

  LogModel.fromMap(Map map) {
    this.logId = map['log_id'];
    this.callerName = map['caller_name'];
    this.callerPic = map['caller_pic'];
    this.receiverName = map['rec_name'];
    this.receiverPic = map['rec_pic'];
    this.callStatus = map['call_status'];
    this.timestamp = map['timestamp'];
  }
}
