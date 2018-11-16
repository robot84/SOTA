#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
FILE *f;
if((f=fopen("summits.num","r"))==NULL) {
printf("DUPPPA\n");
exit(1);
}
int d,e;
fscanf(f,"%d\n",&d);
while(!feof(f)){
fscanf(f,"%d\n",&e);
if(e==(d+1)) {d=e;}
else 
{
printf("Zagubiono: %d\n",d+1);
d=e;
}
}
fclose(f);
return 0;
}
