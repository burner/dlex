module dlex.sparsebitset;

import dlex.enumeration;

import hurt.conv.conv;
import hurt.util.array;
import hurt.util.stacktrace;
import hurt.string.stringbuffer;

//final class SparseBitSet implements Cloneable {
final class SparseBitSet {
	/** Sorted array of bit-block offsets. */
	int offs[];
	/** Array of bit-blocks; each holding BITS bits. */
	long bits[];
	/** Number of blocks currently in use. */
	int size;
	/** log base 2 of BITS, for the identity: x/BITS == x >> LG_BITS */
	static private immutable LG_BITS = 6;
	/** Number of bits in a block. */
	static private immutable BITS = 1 << LG_BITS;
	/** BITS-1, using the identity: x % BITS == x & (BITS-1) */
	static private immutable BITS_M1 = BITS - 1;

	/** Creates an empty set.  */
	public this() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"this");
		bits = new long[4];
		offs = new int[4];
		size = 0;
	}

	/** Creates an empty set with the specified size.
	 * 
	 * @param nbits
	 *            the size of the set
	 */
	public this(int nbits) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"this");
		debug st.putArgs("int", "nbits", nbits);
			
		this();
	}

	/**
	 * Creates an empty set with the same size as the given set.
	 */
	public this(SparseBitSet set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"this");
		debug st.putArgs("string", "set", set.toString());
			
		bits = new long[set.size];
		offs = new int[set.size];
		size = 0;
	}

	private void new_block(int bnum) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"new_block");
		debug st.putArgs("int", "bnum", bnum);
			
		new_block(bsearch(bnum), bnum);
	}

	private void new_block(int idx, int bnum) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"new_block");
		debug st.putArgs("int", "idx", idx, 
			"int", "bnum", bnum);

		if(size == bits.length) { // resize
			long[] nbits = new long[size * 3];
			int[] noffs = new int[size * 3];
			arrayCopy(bits, 0, nbits, 0, size);
			arrayCopy(offs, 0, noffs, 0, size);
			bits = nbits;
			offs = noffs;
		}
		assert(size < bits.length);
		insert_block(idx, bnum);
	}

	private void insert_block(int idx, int bnum) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"insert_block");
		debug st.putArgs("int", "idx", idx, 
			"int", "bnum", bnum);

		assert(idx <= size);
		assert(idx == size || offs[idx] != bnum);
		arrayCopy(bits, idx, bits, idx + 1, size - idx);
		arrayCopy(offs, idx, offs, idx + 1, size - idx);
		offs[idx] = bnum;
		bits[idx] = 0; // clear them bits.
		size++;
	}

	private int bsearch(int bnum) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"bsearch");
		debug st.putArgs("int", "bnum", bnum);
			
		int l = 0, r = size; // search interval is [l, r)
		while(l < r) {
			int p = (l + r) / 2;
			if(bnum < offs[p])
				r = p;
			else if(bnum > offs[p])
				l = p + 1;
			else
				return p;
		}
		assert(l == r);
		return l; // index at which the bnum *should* be, if it's not.
	}

	/**
	 * Sets a bit.
	 * 
	 * @param bit
	 *            the bit to be set
	 */
	public void set(int bit) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"set");
		debug st.putArgs("int", "bit", bit);
			
		int bnum = bit >> LG_BITS;
		int idx = bsearch(bnum);
		if(idx >= size || offs[idx] != bnum)
			new_block(idx, bnum);
		bits[idx] |= (1L << (bit & BITS_M1));
	}

	/**
	 * Clears a bit.
	 * 
	 * @param bit
	 *            the bit to be cleared
	 */
	public void clear(int bit) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"clear");
		debug st.putArgs("int", "bit", bit);
			
		int bnum = bit >> LG_BITS;
		int idx = bsearch(bnum);
		if(idx >= size || offs[idx] != bnum)
			new_block(idx, bnum);
		bits[idx] &= ~(1L << (bit & BITS_M1));
	}

	/**
	 * Clears all bits.
	 */
	public void clearAll() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"clearAll");
		size = 0;
	}

	/**
	 * Gets a bit.
	 * 
	 * @param bit
	 *            the bit to be gotten
	 */
	public bool get(int bit) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"get");
		debug st.putArgs("int", "bit", bit);
			
		int bnum = bit >> LG_BITS;
		int idx = bsearch(bnum);
		if(idx >= size || offs[idx] != bnum)
			return false;
		return 0 != (bits[idx] & (1L << (bit & BITS_M1)));
	}

	/**
	 * Logically ANDs this bit set with the specified set of bits.
	 * 
	 * @param set
	 *            the bit set to be ANDed with
	 */
	public void and(SparseBitSet set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"and");
		debug st.putArgs("string", "set", set.toString());
			
		binop(this, set, function(long a, long b) { return a & b; });
	}

	/**
	 * Logically ORs this bit set with the specified set of bits.
	 * 
	 * @param set
	 *            the bit set to be ORed with
	 */
	public void or(SparseBitSet set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"or");
		debug st.putArgs("string", "set", set.toString());
			
		binop(this, set, function(long a, long b) { return a | b; });
	}

	/**
	 * Logically XORs this bit set with the specified set of bits.
	 * 
	 * @param set
	 *            the bit set to be XORed with
	 */
	public void xor(SparseBitSet set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"xor");
		debug st.putArgs("string", "set", set.toString());
			
		binop(this, set, function(long a, long b) { return a ^ b; });
	}

	// BINARY OPERATION MACHINERY
	private interface BinOp {
		public long op(long a, long b);
	}
/*
	private static long and(long a, long b) {
		return a & b;
	}

	private static long or(long a, long b) {
		return a | b;
	}

	private static long or(long a, long b) {
		return a ^ b;
	}

	class BinAnd : BinOp {
		public final long op(long a, long b) {
			debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
				"op");
			debug st.putArgs("long", "a", a, 
				"long", "b", b);
			return a & b;
		}
	}

	class BinOr : BinOp {
		public final long op(long a, long b) {
			debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
				"op");
			debug st.putArgs("long", "a", a, 
				"long", "b", b);
			return a | b;
		}
	}

	class BinXor : BinOp {
		public final long op(long a, long b) {
			debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
				"op");
			debug st.putArgs("long", "a", a, 
				"long", "b", b);
			return a ^ b;
		}
	}*/

	//private static final void binop(SparseBitSet a, SparseBitSet b, BinOp op) {
	private static final void binop(SparseBitSet a, SparseBitSet b, long function(long a, long b) op ) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"binop");
			
		int nsize = a.size + b.size;
		long[] nbits;
		int[] noffs;
		int a_zero, a_size;
		// be very clever and avoid allocating more memory if we can.
		if(a.bits.length < nsize) { // oh well, have to make working space.
			nbits = new long[nsize];
			noffs = new int[nsize];
			a_zero = 0;
			a_size = a.size;
		} else { // reduce, reuse, recycle!
			nbits = a.bits;
			noffs = a.offs;
			a_zero = a.bits.length - a.size;
			a_size = a.bits.length;
			arrayCopy(a.bits, 0, a.bits, a_zero, a.size);
			arrayCopy(a.offs, 0, a.offs, a_zero, a.size);
		}
		// ok, crunch through and binop those sets!
		nsize = 0;
		for(int i = a_zero, j = 0; i < a_size || j < b.size;) {
			long nb;
			int no;
			if(i < a_size && (j >= b.size || a.offs[i] < b.offs[j])) {
				nb = op(a.bits[i], 0);
				no = a.offs[i];
				i++;
			} else if(j < b.size && (i >= a_size || a.offs[i] > b.offs[j])) {
				nb = op(0, b.bits[j]);
				no = b.offs[j];
				j++;
			} else { // equal keys; merge.
				nb = op(a.bits[i], b.bits[j]);
				no = a.offs[i];
				i++;
				j++;
			}
			if(nb != 0) {
				nbits[nsize] = nb;
				noffs[nsize] = no;
				nsize++;
			}
		}
		a.bits = nbits;
		a.offs = noffs;
		a.size = nsize;
	}

	/**
	 * Gets the hashcode.
	 */
	public hash_t toHash() {
		long h = 1234;
		for(int i = 0; i < size; i++)
			h ^= bits[i] * offs[i];
		return conv!(long,int)((h >> 32) ^ h);
	}

	bool opEquals(Object t) {
		/*if(is(o == CSpec)) {
			SparseBitSet f = cast(SparseBitSet)o;

			// test the members
			if(f.offs.length != this.offs.length) 
				return false;
			if(f.bits.length != this.bits.length) 
				return false;
			if(f.size != this.size)
				return false;

			foreach(idx, it; offs) {
				if(it != offs[idx])
					return false;
			}
			foreach(idx, it; bits) {
				if(it != bits[idx])
					return false;
			}
			
		} else {
			return false;
		}*/
		if(!is(t == SparseBitSet)) {
			return false;
		}
		SparseBitSet o = cast(SparseBitSet)t;

		for(int i = 0, j = 0; i < this.size || j < o.size;) {
			if(i < this.size && (j >= o.size || this.offs[i] < o.offs[j])) {
				if(this.bits[i++] != 0)
					return false;
			} else if(j < o.size && (i >= this.size || this.offs[i] > o.offs[j])) {
				if(o.bits[j++] != 0)
					return false;
			} else { // equal keys
				if(this.bits[i++] != o.bits[j++])
					return false;
			}
		}
		return true;
	}

	int opCmp(Object o) {
		assert(0, "This should never been has called");
		SparseBitSet f = cast(SparseBitSet)o;
		if(!f) {
			return -1;
		}
		if(f == this) {
			return 0;
		} else {
			return 1;
		}
	}

	/**
	 * Calculates and returns the set's size
	 */
	public int getSize() {
		return (size == 0) ? 0 : ((1 + offs[size - 1]) << LG_BITS);
	}

	/**
	 * Compares this object against the specified object.
	 * 
	 * @param obj
	 *            the object to commpare with
	 * @return true if the objects are the same; false otherwise.
	 */
	public bool equals(Object obj) {
		if((obj !is null) && is(obj == SparseBitSet))
			return equals(this, cast(SparseBitSet) obj);
		return false;
	}

	/**
	 * Compares two SparseBitSets for equality.
	 * 
	 * @return true if the objects are the same; false otherwise.
	 */
	public static bool equals(SparseBitSet a, SparseBitSet b) {
		for(int i = 0, j = 0; i < a.size || j < b.size;) {
			if(i < a.size && (j >= b.size || a.offs[i] < b.offs[j])) {
				if(a.bits[i++] != 0)
					return false;
			} else if(j < b.size && (i >= a.size || a.offs[i] > b.offs[j])) {
				if(b.bits[j++] != 0)
					return false;
			} else { // equal keys
				if(a.bits[i++] != b.bits[j++])
					return false;
			}
		}
		return true;
	}

	/**
	 * Clones the SparseBitSet.
	 */
	public SparseBitSet clone() {
		SparseBitSet set = new SparseBitSet();
		set.bits = this.bits.dup;
		set.offs = this.offs.dup;
		set.size = this.size;
		return set;
	}

	/**
	 * Return an <code>Enumeration</code> of <code>Integer</code>s which
	 * represent set bit indices in this SparseBitSet.
	 */
	public Enumeration!(long) elements() {
		return new Enumeration!(long)(this.offs, this.bits, this.BITS, this.size);
	}

	/**
	 * Converts the SparseBitSet to a String.
	 */
	public override string toString() {
		StringBuffer!(char) sb = new StringBuffer!(char)();
		sb.pushBack('{');
		for(Enumeration!(long) e = elements(); e.hasMoreElements();) {
			if(sb.getSize() > 1)
				sb.pushBack(", ");
			sb.pushBack(conv!(long,string)(e.nextElement()));
		}
		sb.pushBack('}');
		return sb.toString();
	}

	/** Check validity. */
	private bool isValid() {
		if(bits.length != offs.length)
			return false;
		if(size > bits.length)
			return false;
		if(size != 0 && 0 <= offs[0])
			return false;
		for(int i = 1; i < size; i++)
			if(offs[i] < offs[i - 1])
				return false;
		return true;
	}

	/** Self-test.
	public static void main(String[] args) {
		final int ITER = 500;
		final int RANGE = 65536;
		SparseBitSet a = new SparseBitSet();
		assert(!a.get(0) && !a.get(1));
		assert(!a.get(123329));
		a.set(0);
		assert(a.get(0) && !a.get(1));
		a.set(1);
		assert(a.get(0) && a.get(1));
		a.clearAll();
		assert(!a.get(0) && !a.get(1));
		java.util.Random r = new java.util.Random();
		java.util.Vector v = new java.util.Vector();
		for(int n = 0; n < ITER; n++) {
			int rr = ((r.nextInt() >>> 1) % RANGE) << 1;
			a.set(rr);
			v.addElement(new Integer(rr));
			// check that all the numbers are there.
			assert(a.get(rr) && !a.get(rr + 1) && !a.get(rr - 1));
			for(int i = 0; i < v.size(); i++)
				assert(a.get(((Integer) v.elementAt(i)).intValue()));
		}
		SparseBitSet b = (SparseBitSet) a.clone();
		assert(a.equals(b) && b.equals(a));
		for(int n = 0; n < ITER / 2; n++) {
			int rr = (r.nextInt() >>> 1) % v.size();
			int m = ((Integer) v.elementAt(rr)).intValue();
			b.clear(m);
			v.removeElementAt(rr);
			// check that numbers are removed properly.
			assert(!b.get(m));
		}
		assert(!a.equals(b));
		SparseBitSet c = (SparseBitSet) a.clone();
		SparseBitSet d = (SparseBitSet) a.clone();
		c.and(a);
		assert(c.equals(a) && a.equals(c));
		c.xor(a);
		assert(!c.equals(a) && c.size() == 0);
		d.or(b);
		assert(d.equals(a) && !b.equals(d));
		d.and(b);
		assert(!d.equals(a) && b.equals(d));
		d.xor(a);
		assert(!d.equals(a) && !b.equals(d));
		c.or(d);
		c.or(b);
		assert(c.equals(a) && a.equals(c));
		c = (SparseBitSet) d.clone();
		c.and(b);
		assert(c.size() == 0);
		System.out.println("Success.");
	} */
}
