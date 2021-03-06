module dlex.stack;

final class Stack(T) {
	private T[] stack;
	private int stptr;
	private uint growthrate;

	this(uint size = 128, uint growthrate = 2) {
		if(growthrate < 2) {
			this.growthrate = 2;
		} else {
			this.growthrate = growthrate;
		}
		this.stack = new T[size];
		this.stptr = -1;
	}

	Stack!(T) push(T elem) {
		if(this.stptr+1 == stack.length) {
			this.stack.length = this.stack.length*this.growthrate;
		}
		this.stack[++this.stptr] = elem;
		return this;
	}

	T pop() {
		if(this.stptr < 0) {
			assert(0);
		}
		return this.stack[this.stptr--];
	}

	bool empty() const {
		return this.stptr < 0 ? true : false;
	}

	T top() {
		if(this.stptr < 0) {
			assert(0);
		}
		return this.stack[this.stptr];
	}

	uint getSize() const {
		return this.stptr+1;
	}

	uint getCapazity() const {
		return this.stack.length;
	}

	T elementAt(in uint idx) {
		if(idx >= this.stptr) {
			assert(0, "Index to big");
		}
		return this.stack[idx];
	}

	Stack!(T) setCapazity(in uint nSize) {
		if(this.stack.length >= nSize) {
			return this;
		} else {
			this.stack.length = nSize;
			return this;
		}
	}

	void clear() {
		this.stptr = 0;	
	}
}
