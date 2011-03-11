module dlex.enumeration;

public class Enumeration(T) {
	int idx;
	int bitU;
	/** Sorted array of bit-block offsets. */
	int offs[];
	/** Array of bit-blocks; each holding BITS bits. */
	T[] bits;
	int size;
	int LG_BITS;
	int BITS;
	
	this(int offs[], T[] bits, int BITS, int size) {
		this.idx = -1;
		this.bitU = BITS;
		this.BITS = BITS;
		this.offs = offs;
		this.bits = bits;
		this.size = size;
		this.advance();
	}

	public bool hasMoreElements() {
		return (idx < size);
	}

	public T nextElement() {
		T r = bitU + (offs[idx] << LG_BITS);
		this.advance();
		return r;
	}

	private void advance() {
		while(idx < size) {
			while(++bitU < BITS)
				if(0 != (bits[idx] & (1L << bitU)))
					return;
			idx++;
			bitU = -1;
		}
	}
}
