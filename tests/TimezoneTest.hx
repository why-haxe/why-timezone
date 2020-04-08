package;

using why.Timezone;
using DateTools;

@:asserts
class TimezoneTest {
	public function new() {
		trace(Timezone.local().toString());
	}

	@:variant(16, '2020-01-01 16:00:00', 'GMT+16')
	@:variant(8, '2020-01-01 08:00:00', 'GMT+8')
	@:variant(0, '2020-01-01 00:00:00', 'UTC')
	@:variant(-8, '2019-12-31 16:00:00', 'GMT-8')
	@:variant(-16, '2019-12-31 08:00:00', 'GMT-16')
	public function format(hours:Int, str:String, tz:String) {
		var date = utc(2020, 0, 1, 0, 0, 0);
		var timezone = new Timezone(hours);
		asserts.assert(date.formatWithTimezone(timezone) == str);
		asserts.assert(timezone.toString() == tz);
		return asserts.done();
	}

	inline function utc(year:Int, month:Int, date:Int, hour:Int, minute:Int, second:Int) {
		var date = new Date(year, month, date, hour, minute, second);
		var offset = date.getTimezoneOffset();
		return date.delta(-offset * 60000);
	}
}
