#include "abc/object.h"


object::object( obj_type typ, int i )
: m_type( typ )
, m_value( i )
{}

obj_type object::type() const
{
	return m_type;
}

int object::doubled() const
{
	return 2 * m_value;
}

int object::tripled() const
{
	return 3 * m_value;
}

