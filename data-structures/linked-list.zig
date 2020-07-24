const assert = @import("std").debug.assert;

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node = null,
            next: ?*Node = null,
            value: T,

            // sets next and prev for a node
            pub fn link(self: *LinkedList(T).Node, prev: ?*LinkedList(T).Node, next: ?*LinkedList(T).Node) void {
                // TODO error handling
                assert(self.prev == null);
                assert(self.next == null);

                self.prev = prev;
                self.next = next;

                if (prev) |justPrev| {
                    // TODO exception instead
                    assert(justPrev.next == next);
                    justPrev.next = self;
                }

                if (next) |justNext| {
                    // TODO exception instead
                    assert(justNext.prev == prev);
                    justNext.prev = self;
                }
            }

            // unsets the next and prev for a node, links prev directly to next
            pub fn unlink(self: *LinkedList(T).Node) void {
                if (self.prev) |justPrev| {
                    justPrev.next = self.next;
                    self.prev = null;
                }

                if (self.next) |justNext| {
                    justNext.prev = self.prev;
                    self.next = null;
                }
            }
        };

        // add node to end
        pub fn append(self: *LinkedList(T), elem: *Node) void {
            elem.link(self.tail, null);

            if (self.len == 0) {
                assert(self.head == null);
                self.head = elem;
            }
            self.tail = elem;
            self.len += 1;
        }

        // add node to front
        pub fn prepend(self: *LinkedList(T), elem: *Node) void {
            elem.link(null, self.head);

            if (self.len == 0) {
                assert(self.tail == null);
                self.tail = elem;
            }
            self.head = elem;
            self.len += 1;
        }

        // removes node from list
        pub fn remove(self: *LinkedList(T), elem: *Node) void {
            // TODO exception instead
            assert(self.len > 0);

            if (self.head == elem) {
                self.head = elem.next;
            }

            if (self.tail == elem) {
                self.tail = elem.prev;
            }

            // TODO ensure node is in the given list
            elem.unlink();

            self.len -= 1;
        }

        // get the node at the given index
        pub fn nodeAt(self: *LinkedList(T), index: usize) ?*Node {
            if (self.len <= index) {
                // TODO exception instead
                return null;
            }

            // TODO iterate in reverse if near the end
            var curr_index: usize = 0;
            var curr_node = self.head.?;
            return while (curr_index < self.len) : ({
                curr_index += 1;
                curr_node = curr_node.next.?;
            }) {
                if (curr_index == index) {
                    break curr_node;
                }
            } else null;
        }

        // TODO
        pub fn removeAt(self: *LinkedList(T), index: usize) Node {}

        // insert a node at the given index
        pub fn insertAt(self: *LinkedList(T), elem: *Node, index: usize) void {
            // TODO exception instead
            assert(self.len >= index);

            if (index == 0) {
                self.prepend(elem);
            } else if (index == self.len) {
                self.append(elem);
            } else {
                var prev = self.nodeAt(index - 1).?;
                var next = prev.next.?;

                elem.link(prev, next);
                self.len += 1;
            }
        }

        head: ?*Node = null,
        tail: ?*Node = null,
        len: usize = 0,
    };
}

test "create node type" {
    var int_list = LinkedList(i32){};
    assert(int_list.len == 0);
    assert(int_list.head == null);
    assert(int_list.tail == null);
}

test "append to linked list" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };

    int_list.append(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node1);

    int_list.append(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node2);
}

test "prepend to linked list" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };

    int_list.prepend(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node1);

    int_list.prepend(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node2);
    assert(int_list.tail == &node1);
}

test "remove from linked list" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };
    var node3 = LinkedList(i32).Node{
        .value = 3,
    };

    int_list.append(&node1);
    int_list.append(&node2);
    int_list.append(&node3);

    int_list.remove(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node3);

    int_list.remove(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node3);
    assert(int_list.tail == &node3);

    int_list.remove(&node3);
    assert(int_list.len == 0);
    assert(int_list.head == null);
    assert(int_list.tail == null);
}

test "get node at index" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };
    var node3 = LinkedList(i32).Node{
        .value = 3,
    };

    int_list.append(&node1);
    int_list.append(&node2);
    int_list.append(&node3);

    assert(int_list.nodeAt(0) == &node1);
    assert(int_list.nodeAt(1) == &node2);
    assert(int_list.nodeAt(2) == &node3);
    assert(int_list.nodeAt(3) == null);
}

test "insert node at index" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };
    var node3 = LinkedList(i32).Node{
        .value = 3,
    };

    int_list.insertAt(&node1, 0);
    int_list.insertAt(&node2, 1);
    int_list.insertAt(&node3, 1);

    assert(int_list.nodeAt(0) == &node1);
    assert(int_list.nodeAt(1) == &node3);
    assert(int_list.nodeAt(2) == &node2);
}
