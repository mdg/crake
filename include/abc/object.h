#ifndef ABC_OBJECT_H
#define ABC_OBJECT_H


class object
{
public:
	object( int i );

	int doubled() const;
	int tripled() const;

private:
	int m_value;
};


#endif

