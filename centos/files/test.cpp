// Copyright 2014-present Trifacta Inc.

#include <iostream>
#include <thread>

static const int num_threads = 10;

void call_from_thread() {
  std::cout << "Looks good from up here" << std::endl;
}

int main() {
  std::thread t[num_threads];

  // Launch a group of threads
  for (int i = 0; i < num_threads; ++i) {
    t[i] = std::thread(call_from_thread);
  }

  std::cout << "Launched from the main\n";

  // Join the threads with the main thread
  for (int i = 0; i < num_threads; ++i) {
    t[i].join();
  }

  return 0;
}
