#ifndef ABC_OBJECT_H
#define ABC_OBJECT_H

#include "obj_type.h"


class object
{
public:
	object( obj_type, int i );

	obj_type type() const;
	int doubled() const;
	int tripled() const;

private:
	obj_type m_type;
	int m_value;
};


#endif

