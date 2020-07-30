const assert = @import("std").debug.assert;

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node = null,
            next: ?*Node = null,
            value: T,

            const LinkingError = error.LinkingError;

            // sets next and prev for a node
            pub fn link(self: *LinkedList(T).Node, prev: ?*LinkedList(T).Node, next: ?*LinkedList(T).Node) !void {
                // TODO use transactions so no changes are made when an error occurs
                if (self.prev != null or self.prev != null) {
                    return error.LinkingError;
                }

                self.prev = prev;
                self.next = next;

                if (prev) |justPrev| {
                    if (justPrev.next != next) {
                        return error.LinkingError;
                    }
                    justPrev.next = self;
                }

                if (next) |justNext| {
                    if (justNext.prev != prev) {
                        return error.LinkingError;
                    }
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

        const LinkedListError = error{OutOfRange};

        // add node to end
        pub fn append(self: *LinkedList(T), elem: *Node) !void {
            try self.insertAt(elem, self.len);
        }

        // add node to front
        pub fn prepend(self: *LinkedList(T), elem: *Node) !void {
            try self.insertAt(elem, 0);
        }

        // removes node from list
        pub fn remove(self: *LinkedList(T), elem: *Node) !void {
            if (self.len <= 0) {
                return error.OutOfRange;
            }

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

            // small optimization
            if (index == 0) {
                return self.head;
            } else if (index == self.len - 1) {
                return self.tail;
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

        // removes the node at the given index and returns it
        pub fn removeAt(self: *LinkedList(T), index: usize) !*Node {
            if (self.len <= index) {
                return error.OutOfRange;
            }

            var elem = self.nodeAt(index).?;
            try self.remove(elem);
            return elem;
        }

        // insert a node at the given index
        pub fn insertAt(self: *LinkedList(T), elem: *Node, index: usize) !void {
            if (self.len < index) {
                return error.OutOfRange;
            }

            if (index == 0) {
                try elem.link(null, self.head);
                self.head = elem;
            } else {
                var prev = self.nodeAt(index - 1).?;
                try elem.link(prev, prev.next);
            }

            if (index == self.len) {
                self.tail = elem;
            }

            self.len += 1;
        }

        // remove the node at the end of the list
        pub fn removeLast(self: *LinkedList(T)) *Node {
            return removeAt(self.len - 1);
        }

        // remove the node at the front of the list
        pub fn removeFirst(self: *LinkedList(T)) *Node {
            return removeAt(0);
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

    try int_list.append(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node1);

    try int_list.append(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node2);
    assert(int_list.tail.?.prev == &node1);
}

test "prepend to linked list" {
    var int_list = LinkedList(i32){};
    var node1 = LinkedList(i32).Node{
        .value = 1,
    };
    var node2 = LinkedList(i32).Node{
        .value = 2,
    };

    try int_list.prepend(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node1);

    try int_list.prepend(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node2);
    assert(int_list.tail == &node1);
    assert(int_list.head.?.next == &node1);
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

    try int_list.append(&node1);
    try int_list.append(&node2);
    try int_list.append(&node3);

    try int_list.remove(&node2);
    assert(int_list.len == 2);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node3);

    try int_list.remove(&node1);
    assert(int_list.len == 1);
    assert(int_list.head == &node3);
    assert(int_list.tail == &node3);

    try int_list.remove(&node3);
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

    try int_list.append(&node1);
    try int_list.append(&node2);
    try int_list.append(&node3);

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

    try int_list.insertAt(&node1, 0);
    try int_list.insertAt(&node2, 1);
    try int_list.insertAt(&node3, 1);

    assert(int_list.nodeAt(0) == &node1);
    assert(int_list.nodeAt(1) == &node3);
    assert(int_list.nodeAt(2) == &node2);
}

test "remove from index in linked list" {
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

    try int_list.append(&node1);
    try int_list.append(&node2);
    try int_list.append(&node3);

    const elem = try int_list.removeAt(1);
    assert(int_list.len == 2);
    assert(int_list.head == &node1);
    assert(int_list.tail == &node3);
    assert(elem == &node2);
}
