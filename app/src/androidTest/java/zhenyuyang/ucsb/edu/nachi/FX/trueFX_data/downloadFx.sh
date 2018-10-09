for v in 2009 2010 2011 2012 2013 2014
do
	echo $v

	wget https://www.truefx.com/dev/data/$v/JANUARY-$v/EURUSD-$v-01.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/FEBRUARY-$v/EURUSD-$v-02.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/MARCH-$v/EURUSD-$v-03.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/APRIL-$v/EURUSD-$v-04.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/MAY-$v/EURUSD-$v-05.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/JUNE-$v/EURUSD-$v-06.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/JULY-$v/EURUSD-$v-07.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/AUGUST-$v/EURUSD-$v-08.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/SEPTEMBER-$v/EURUSD-$v-09.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/OCTOBER-$v/EURUSD-$v-10.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/NOVEMBER-$v/EURUSD-$v-11.zip --no-check-certificate
	wget https://www.truefx.com/dev/data/$v/DECEMBER-$v/EURUSD-$v-12.zip --no-check-certificate








done
