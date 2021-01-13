function changeImage() {
  let skkuimg = document.getElementById("skku");
  if(skkuimg.src.indexOf("skku") != -1){
    skkuimg.src = "images/networklab.png";
  }
  else {

    skkuimg.src = "images/skku.png";
  }
}
