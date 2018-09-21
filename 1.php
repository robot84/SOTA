<html>
<body>
<?php
$mygrid = $_GET['mygrid'];
$fagrid = $_GET['fagrid'];
echo "mygrid: $mygrid<br>";
echo "fagrid: $fagrid<br>";
?>
<form action="https://www.chris.org/cgi-bin/showdis" method="post" id="dateForm">
<?php
echo "L1: <input value=$mygrid size=6 name=mygrid><br>";
echo "L2: <input size=6 value=$fagrid name=fagrid><br>";
?>
<script type="text/javascript">
    document.getElementById('dateForm').submit(); // SUBMIT FORM
	</script>
<input type="submit">
</form>

</body>
</html>
