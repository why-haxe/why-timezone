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
		final date = utc(2020, 0, 1, 0, 0, 0);
		final timezone = new Timezone(hours);
		asserts.assert(date.formatWithTimezone(timezone) == str);
		asserts.assert(timezone.toString() == tz);
		return asserts.done();
	}

	@:variant(700, 420)
	@:variant(-700, -420)
	@:variant(830, 510)
	@:variant(-830, -510)
	public function iso8601(v:Int, out:Int) {
		final timezone = Timezone.fromIso8601Style(v);
		asserts.assert(timezone.toInt() == out);
		asserts.assert(timezone.toIso8601Style() == v);
		return asserts.done();
	}

	inline function utc(year:Int, month:Int, date:Int, hour:Int, minute:Int, second:Int) {
		final date = new Date(year, month, date, hour, minute, second);
		final offset = date.getTimezoneOffset();
		return date.delta(-offset * 60000);
	}
}
