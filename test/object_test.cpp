#include "abc/object.h"


/**
 * This is a mock test.  Normally would use an actual testing library,
 * but for simplicity, it's just faked here.
 */
void test_object()
{
	object o( 4 );

	if ( o.doubled() != 8 ) {
		std::cout << "object::doubled() doesn't work.\n";
	}
	if ( o.tripled() != 12 ) {
		std::cout << "object::tripled() doesn't work.\n";
	}
}


int main()
{
	test_object();
}

