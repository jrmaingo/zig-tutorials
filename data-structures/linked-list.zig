const assert = @import("std").debug.assert;

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node = null,
            next: ?*Node = null,
            value: T,
        };

        // add node to end
        pub fn append(self: *LinkedList(T), elem: *Node) void {
            // TODO error handling
            assert(elem.prev == null);
            assert(elem.next == null);

            var maybe_old_tail = self.tail;
            elem.prev = maybe_old_tail;
            if (maybe_old_tail) |old_tail| {
                old_tail.next = elem;
            } else {
                self.head = elem;
            }
            self.tail = elem;
            self.len += 1;
        }

        // add node to front
        pub fn prepend(self: *LinkedList(T), elem: *Node) void {
            // TODO error handling
            assert(elem.prev == null);
            assert(elem.next == null);

            var maybe_old_head = self.head;
            elem.next = maybe_old_head;
            if (maybe_old_head) |old_head| {
                old_head.prev = elem;
            } else {
                self.tail = elem;
            }
            self.head = elem;
            self.len += 1;
        }

        // removes node from list
        pub fn remove(self: *LinkedList(T), elem: *Node) void {
            assert(self.len > 0);

            if (self.len == 1) {
                assert(self.head == elem);
                self.head = null;
                self.tail = null;
            } else {
                // TODO ensure node is in the given list
                var prev = elem.prev.?;
                var next = elem.next.?;
                prev.next = next;
                next.prev = prev;
                elem.next = null;
                elem.prev = null;
            }

            self.len -= 1;
        }

        // get the node at the given index
        pub fn nodeAt(self: *LinkedList(T), index: usize) ?*Node {
            if (self.len <= index) {
                // TODO exception instead
                return null;
            }

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

        // TODO
        pub fn insert(self: *LinkedList(T), elem: Node, index: usize) void {}

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
