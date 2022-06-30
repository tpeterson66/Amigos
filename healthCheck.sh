success=0
for i in `seq 1 20`
do 
statusCode=$(curl -s -o /dev/null -w "%{http_code}" https://qa-us-west.azure.interaction.com/auth/status)
if [[ $statusCode == 200 ]];
then
  success=$(( success+1 ))
fi
done
if [[ $success -le 18 ]];
then
  echo "Did not meet success criteria of 18, got $success"
  exit 1
else
  echo "Successfully passed the test, got $success"
  exit 0
fi
