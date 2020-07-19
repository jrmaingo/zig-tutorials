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
