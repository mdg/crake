#include "abc/object.h"


object::object( int i )
: m_value( i )
{}

int object::doubled() const
{
	return 2 * m_value;
}

int object::tripled() const
{
	return 3 * m_value;
}

