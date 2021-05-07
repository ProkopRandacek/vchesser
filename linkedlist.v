// use the linked list module when it implements generic types

struct List {
pub mut:
	count u64
	first &ListNode
	last  &ListNode
}

struct ListNode {
pub mut:
	val  Move
	next &ListNode = 0
}

// O(n)
[direct_array_access; manualfree]
pub fn create(arr []Move) &List {
	assert arr.len != 0
	mut n := &ListNode{
		val: arr[0]
		next: 0
	}
	mut l := &List{
		first: n
		last: n
		count: 1
	}

	for i in 1 .. arr.len { // faster than `for i in arr[1..] {`
		l.append(arr[i])
	}
	return l
}

// O(n)
pub fn (l &List) free() {
	mut pos := l.first
	for _ in 0 .. l.count {
		tmp := pos.next
		unsafe { free(pos) }
		pos = tmp
	}
	unsafe { free(l) }
}

// O(1)
[inline; manualfree]
pub fn (mut l List) append(val Move) {
	l.last.next = &ListNode{
		val: val
		next: 0
	}
	l.last = l.last.next
	l.count++
}

// O(n)
[inline]
pub fn (mut l List) pop() {
	todel := l.first
	l.first = l.first.next
	l.count--
	unsafe {
		free(todel)
	}
}

pub fn (l &List) to_array() []Move {
	mut arr := []Move{cap: int(l.count)}
	mut pos := l.first
	for _ in 0 .. l.count {
		arr << pos.val
		pos = pos.next
	}
	return arr
}
