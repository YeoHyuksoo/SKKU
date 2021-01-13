function convert() {
  if(document.getElementById("convert").value == "kgtopounds"){
    let val = document.getElementById("value").value;
    val*=2.20462262;
    document.getElementById("answer").innerHTML = val;
  }
  else{
    let val = document.getElementById("value").value;
    val/=2.20462262;
    document.getElementById("answer").innerHTML = val;
  }
}
