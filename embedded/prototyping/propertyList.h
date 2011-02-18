/*
    Heterogeneous property list implementation
*/

#include <String>

class PropertyList {
  private:
	Property& pList[];
  public:
	String get(int index);
	void set(int index, Property property);  /* We'd do pList[index] = &property
											 //	which would work for any GeneralProperty */
};

class Property {
  public:
	virtual String get(void);
	virtual void set(void *data);
};

template <typename T> class GeneralProperty: public Property {
	private:
		T data;
	public:
		String get(void);     // Return data cast as (T)
		void set(void *data);   
};