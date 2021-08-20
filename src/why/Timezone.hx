package why;

import why.unit.time.*;

using StringTools;
using DateTools;

@:jsonStringify(tz -> tz.toMinutes())
@:jsonParse(why.Timezone.fromMinutes)
abstract Timezone(Second) {
	public static final UTC = new Timezone(new Second(0));
	public static inline function GMT(hours:Hour) return new Timezone(hours);
	
	public inline function new(seconds:Second)
		this = seconds;
	

	public static inline function local():Timezone {
		return new Timezone(new Minute(-Date.now().getTimezoneOffset()));
	}
	
	public inline static function formatWithTimezone(date:Date, timezone:Timezone, ?format:String) {
		return timezone.formatDate(date, format);
	}
	
	public function createDate(year, month, date, hours, minutes, seconds) {
		final date = new Date(year, month, date, hours, minutes, seconds);
		final offset = new Minute(date.getTimezoneOffset());
		return date.delta((-(this + (offset:Second)):Millisecond).toFloat());
	}

	/**
	 * Format the given date (in caller's timezone) to this timezone
	 * For example, on a machine with local timezone at GMT+8, 
	 * `Timezone.UTC.formatDate(new Date(2000,0,1,0,0,0), '%F %T')` will give "1999-12-31 16:00:00"
	 */
	public function formatDate(local:Date, ?format:String) {
		final target = getDate(local);
		return
			if (format == null)
				target.toString();
			else
				target.format(format);
	}
	
	public function getDate(local:Date):TimezoneLocalDate {
		final callerOffset = new Minute(Date.now().getTimezoneOffset());
		return cast local.delta((((this:Second) + (callerOffset:Second)):Millisecond).toFloat());
	}

	public function toString() {
		final hours = (this:Hour).toFloat();
		return hours == 0 ? 'UTC' : 'GMT' + (hours > 0 ? '+' : '') + hours;
	}

	@:from
	public static inline function fromMinutes(v:Minute):Timezone
		return new Timezone(v);

	@:to
	public inline function toMinutes():Minute
		return this;
	
	/**
	 * Convert from string in ISO8601 style
	 * @param v Example: -08:00 or 730 means +07:30
	 * @return Timezone
	 */
	public static function fromIso8601Style(v:String):Timezone {
		final regex = ~/^([+-])(\d{2}):(\d{2})$/;
		if(regex.match(v)) {
			final sign = regex.matched(1) == '+' ? 1 : -1;
			final hours = Std.parseInt(regex.matched(2));
			final minutes = Std.parseInt(regex.matched(3));
			return new Timezone(new Minute(sign * (hours * 60 + minutes)));
		} else {
			throw '"$v" is invalid ISO8601 timezone format. Correct examples: "+08:00" or "-07:30"';
		}
	}
	
	/**
	 * Convert to string in ISO8601 style
	 * @return String
	 */
	public function toIso8601Style():String {
		final sign = this.toFloat() > 0 ? '+' : '-';
		final seconds = Math.abs(this.toFloat());
		final hours = Std.int(seconds / 3600);
		final minutes = Std.int((seconds - hours * 3600) / 60);
		return sign + '${Math.abs(hours)}'.lpad('0', 2) + ':' + '$minutes'.lpad('0', 2);
	}

	#if tink_stringly
	@:to
	public inline function toStringly():tink.Stringly
		return this.toFloat();

	@:from
	public static inline function fromStringly(v:tink.Stringly):Timezone
		return new Timezone(new Minute((v : Int)));
	#end

	#if tink_url
	@:from
	public static inline function fromPortion(v:tink.url.Portion):Timezone
		return fromStringly(v);
	#end
}


/**
 * A timezone-local date which is only useful for formatting/display purpose
 */
@:forward(getDate, getDay, getFullYear, getHours, getMinutes, getMonth, getSeconds, toString)
abstract TimezoneLocalDate(Date) {
	// forward DateTools functions
	public inline function format(f)
		return this.format(f);
	
	public inline function getMonthDays()
		return this.getMonthDays();
	
	public inline function delta(s:Second):TimezoneLocalDate
		return cast this.delta((s:Millisecond).toFloat());
}