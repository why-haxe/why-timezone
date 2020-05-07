package why;

using DateTools;

// timezone representation in minutes
// e.g. GMT+8 would be 8 * 60 = 480
abstract Timezone(Int) {
	public static var UTC = new Timezone(0);
	public static inline function GMT(hours:Float) return new Timezone(hours);
	
	public inline function new(hours:Float)
		this = Math.round(hours * 60);
	

	public static inline function local():Timezone {
		return cast -Date.now().getTimezoneOffset();
	}
	
	public inline static function formatWithTimezone(date:Date, timezone:Timezone, ?format:String) {
		return timezone.formatDate(date, format);
	}

	/**
	 * Format the give date (in caller's timezone) to this timezone
	 */
	public function formatDate(local:Date, ?format:String) {
		var target = getDate(local);
		return
			if (format == null)
				target.toString();
			else
				target.format(format);
	}
	
	public function getDate(local:Date) {
		var callerOffset = Date.now().getTimezoneOffset();
		return local.delta((this + callerOffset) * 60000);
	}

	public function toString() {
		var hours = this / 60;
		return hours == 0 ? 'UTC' : 'GMT' + (hours > 0 ? '+' : '') + hours;
	}

	public inline function toInt():Int
		return this;

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

	#if tink_json
	@:to function toRepresentation():tink.json.Representation<Int>
		return new tink.json.Representation(this);

	@:from static function ofRepresentation<T>(rep:tink.json.Representation<Int>):Timezone
		return cast rep.get();
	#end
}
