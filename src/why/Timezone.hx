package why;

using DateTools;

// timezone representation in minutes
// e.g. GMT+8 would be 8 * 60 = 480
@:jsonStringify(tz -> tz.toMinutes())
@:jsonParse(why.Timezone.fromMinutes)
abstract Timezone(Int) {
	public static final UTC = new Timezone(0);
	public static inline function GMT(hours:Float) return new Timezone(hours);
	
	public inline function new(hours:Float)
		this = Math.round(hours * 60);
	

	public static inline function local():Timezone {
		return cast -Date.now().getTimezoneOffset();
	}
	
	public inline static function formatWithTimezone(date:Date, timezone:Timezone, ?format:String) {
		return timezone.formatDate(date, format);
	}
	
	public function createDate(year, month, date, hours, minutes, seconds) {
		final date = new Date(year, month, date, hours, minutes, seconds);
		return date.delta(-(this + date.getTimezoneOffset()) * 60000);
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
	
	public function getDate(local:Date) {
		final callerOffset = Date.now().getTimezoneOffset();
		return local.delta((this + callerOffset) * 60000);
	}

	public function toString() {
		final hours = this / 60;
		return hours == 0 ? 'UTC' : 'GMT' + (hours > 0 ? '+' : '') + hours;
	}

	public static inline function fromMinutes(v:Int):Timezone
		return cast v;

	public inline function toMinutes():Int
		return this;

	@:deprecated('use toMinutes instead')
	public inline function toInt():Int
		return this;
	
	// e.g. In integers: -800 means -08:00 or 730 means +07:30
	public static function fromIso8601Style(v:Int):Timezone {
		final hours = Std.int(v / 100);
		final minutes = v % 100;
		return cast hours * 60 + minutes;
	}
	
	public function toIso8601Style():Int {
		final hours = Std.int(this / 60);
		final minutes = this % 60;
		return hours * 100 + minutes;
	}

	#if tink_stringly
	@:to
	public inline function toStringly():tink.Stringly
		return this;

	@:from
	public static inline function fromStringly(v:tink.Stringly):Timezone
		return cast(v : Int);
	#end

	#if tink_url
	@:from
	public static inline function fromPortion(v:tink.url.Portion):Timezone
		return fromStringly(v);
	#end
}
