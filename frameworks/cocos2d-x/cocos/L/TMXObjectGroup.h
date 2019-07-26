/**
 *	@file	TMXObjectGroup.h
 *	@date	2018/01/25
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	
 */

#ifndef __TMXOBJECTGROUP_20180125000846_H
#define __TMXOBJECTGROUP_20180125000846_H

#include "base/CCRef.h"
#include "base/CCValue.h"
#include "math/CCGeometry.h"
#include "base/CCVector.h"
#include "TMXObject.h"

USING_NS_CC;

namespace L {

/** 
 *	@brief TMX对象组
 */
class CC_DLL TMXObjectGroup : public Ref {
public:
	TMXObjectGroup();
	virtual ~TMXObjectGroup();

	// 解析对象组
	void parseObjectGroup(xml_node<> *node);

	const std::string& getName() const { return _name; }
	const ValueMap& getProperties() const { return _properties; }
	const Value& getProperty(const std::string &name) { return _properties[name]; }
	const Vector<TMXObject*>& getObjects() const { return _objects; }

protected:

	std::string				_name;
	Vec2					_offset;
	ValueMap				_properties;
	Vector<TMXObject*>		_objects;
};

}

#endif //!__TMXOBJECTGROUP_20180125000846_H
