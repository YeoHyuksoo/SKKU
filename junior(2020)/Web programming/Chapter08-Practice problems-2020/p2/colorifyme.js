function changeColor(){
  let color = "#";
  let num = 0;
  for (let i=0;i<6;i++){
    num = getRandomInt(0, 16);
    if(num>=10){
      color += String.fromCharCode(65+num-10);
    }
    else{
      color += String(num);
    }
  }
  document.body.style.backgroundColor = color;
  document.getElementById("mycolor").innerHTML = "Your color is "+color+"!";
}

function getRandomInt(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min;
}
