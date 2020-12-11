List<String> unitList = [
  "BAGS",
  "BOTLES",
  "BOX",
  "CANS",
  "CARTONS",
  "DOZENS",
  "GRAMS",
  "KILOGRAMS",
  "LITRE",
  "METERS",
  "MILILITRE",
  "NUMBERS",
  "PACKS",
  "PAIRS",
  "PIECES",
  "QUINTAL",
  "ROLLS",
  "SQUARE FEET",
  "SQUARE METERS",
  "TABLETS",
];

String getShortForm(String unit) {
  unit = unit.toUpperCase();
  switch (unit) {
    case "BAGS":
      return "BAG";
    case "BOTLES":
      return "BTL";
    case "BOX":
      return "BOX";
    case "CANS":
      return "CAN";
    case "CARTONS":
      return "CTN";
    case "DOZENS": //
      return "DOZ"; //
    case "GRAMS": ////
      return "GM"; //
    case "KILOGRAMS": //
      return "KGS"; //
    case "LITRE": /////
      return "LTR"; //
    case "METERS": //
      return "MT"; //
    case "MILILITRE": //
      return "ML"; //
    case "NUMBERS": //
      return "NOS"; //
    case "PACKS": //
      return "PAC"; //
    case "PAIRS": //
      return "PRS"; //
    case "PIECES": //
      return "PCS"; //
    case "QUINTAL":
      return "QTL";
    case "ROLLS": //
      return "ROL"; //
    case "SQUARE FEET": //
      return "SQF"; //
    case "SQUARE METERS": //
      return "SQM"; //
    case "TABLETS": //
      return "TBS"; //
    default:
      return "UNKNOWN";
  }
}

List<String> getRelatedUnitsList(String unit) {
  switch (unit) {
    case "KGS":
    case "GM":
      return ["KGS", "GM"];
    case "LTR":
    case "ML:":
      return ["LTR", "ML"];
    case "MT":
    case "SQM":
    case "SQF":
      return ["MT", "SQM", "SQF"];
    case "PAC":
    case "PCS":
    case "PRS":
    case "ROL":
    case "TAB":
    case "NOS":
    case "CAN":
    case "BOX":
    case "CTN":
      return ["PAC", "PCS", "PRS", "ROL", "TAB", "NOS", "CAN", "BOX", "CTN"];
    case "DOZ":
      return ["DOZ", "PCS"];
    default:
      return [unit];
  }
}
