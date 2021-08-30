package;

import why.unit.time.*;

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
		final timezone = new Timezone(new Hour(hours));
		asserts.assert(date.formatWithTimezone(timezone) == str);
		asserts.assert(timezone.toString() == tz);
		return asserts.done();
	}
	
	@:variant(8, 2020, 0, 1, 7, 0, 0, '2020-01-01 07:00:00')
	@:variant(16, 2020, 0, 1, 6, 0, 0, '2020-01-01 06:00:00')
	@:variant(-8, 2020, 0, 1, 5, 0, 0, '2020-01-01 05:00:00')
	public function createDate(hours:Int, yy, mm, dd, h, m, s, expected) {
		final timezone = new Timezone(new Hour(hours));
		final date = timezone.createDate(yy, mm, dd, h, m, s);
		asserts.assert(timezone.formatDate(date, '%F %T') == expected);
		return asserts.done();
	}

	@:variant('+07:00', 420)
	@:variant('-07:00', -420)
	@:variant('+08:30', 510)
	@:variant('-08:30', -510)
	public function iso8601(v:String, out:Int) {
		final timezone = Timezone.fromIso8601Style(v);
		asserts.assert(timezone.toMinutes().toFloat() == out);
		asserts.assert(timezone.toIso8601Style() == v);
		return asserts.done();
	}
	
	#if tink_querystring
	
	@:include
	public function query() {
		final timezone = new Timezone(new Hour(8));
		final str = tink.QueryString.build({timezone: timezone});
		final parsed = tink.QueryString.parse((str:{timezone:Timezone}));
		asserts.assert(str == 'timezone=480');
		asserts.assert(timezone.toMinutes() == parsed.sure().timezone.toMinutes());
		return asserts.done();
	}
	
	#end

	inline function utc(year:Int, month:Int, date:Int, hour:Int, minute:Int, second:Int) {
		final date = new Date(year, month, date, hour, minute, second);
		final offset = date.getTimezoneOffset();
		return date.delta(-offset * 60000);
	}
}
