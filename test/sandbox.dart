
class AA{
  dynamic iAm;
  AA(dynamic d){
    print('d: $d ${d.runtimeType}');
    iAm = d;
  }
}


void main(){
   dynamic aString = AA(["a","b","c"]);
   aString.addAll([11,12,15]);






}